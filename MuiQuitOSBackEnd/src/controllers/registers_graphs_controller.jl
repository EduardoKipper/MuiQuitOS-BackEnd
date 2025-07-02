module RegistersGraphsController

using CSV
using DataFrames
using Statistics
using StatsBase
using Plots
using Gadfly
using Dates
using Cairo
using Fontconfig

const PROJECT_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."))
const REGISTERS_CSV = joinpath(PROJECT_ROOT, "database", "registers.csv")
const CACHE_DIR = joinpath(PROJECT_ROOT, "cache")

function generate_registers_graphs()
    # Load data
    if !isfile(REGISTERS_CSV)
        @warn "Arquivo de registros não encontrado: $REGISTERS_CSV"
        return nothing
    end
    df = CSV.read(REGISTERS_CSV, DataFrame)
    if nrow(df) == 0
        @warn "Arquivo de registros está vazio: $REGISTERS_CSV"
        return nothing
    end

    # 1. Count of registers by neighbourhood (pie chart)
    println("Iniciando geração do gráfico de registros por bairro...")
    counts = combine(groupby(df, :neighbourhood), nrow => :count)
    labels = ["$(String(n)): $(c)" for (n, c) in zip(counts.neighbourhood, counts.count)]
    pie(labels, counts.count, title="Registers by Neighbourhood")
    Plots.savefig(joinpath(CACHE_DIR, "registers_by_neighbourhood_pie.png"))
    println("Gráfico de registros por bairro gerado.")

    # 2. Registers by time of day (line chart)
    println("Iniciando geração do gráfico de registros por hora do dia...")
    df.datetime = DateTime.(df.datetime)
    hours = hour.(df.datetime)
    hour_counts = combine(groupby(DataFrame(hour=hours), :hour), nrow => :count)
    Plots.plot(hour_counts.hour, hour_counts.count, seriestype=:line, title="Registers by Time of Day", xlabel="Hour of Day", ylabel="Count", legend=false)
    Plots.savefig(joinpath(CACHE_DIR, "registers_by_time_of_day_line.png"))
    println("Gráfico de registros por hora do dia gerado.")

    # 3. Registers by month (line chart)
    println("Iniciando geração do gráfico de registros por mês...")
    months = Dates.month.(df.datetime)
    years = Dates.year.(df.datetime)
    month_year = [Date(year, month, 1) for (year, month) in zip(years, months)]
    month_counts = combine(groupby(DataFrame(month=month_year), :month), nrow => :count)
    sorted_counts = sort(month_counts, :month)
    Plots.plot(string.(sorted_counts.month), sorted_counts.count, seriestype=:line, title="Registers by Month", xlabel="Month", ylabel="Count", legend=false, xrotation=60)
    Plots.savefig(joinpath(CACHE_DIR, "registers_by_month_line.png"))
    println("Gráfico de registros por mês gerado.")

    # 4. Heatmap de registros por bairro e hora do dia
    println("Iniciando geração do heatmap de registros por bairro e hora do dia...")
    df.hour = hour.(df.datetime)
    bairros = unique(df.neighbourhood)
    horas = 0:23
    heat_data = [sum((df.neighbourhood .== bairro) .& (df.hour .== h)) for bairro in bairros, h in horas]
    Plots.heatmap(
        horas, bairros, heat_data;
        xlabel="Hora do Dia", ylabel="Bairro",
        title="Heatmap de Registros por Bairro e Hora do Dia",
        colorbar_title="Nº de Registros"
    )
    Plots.savefig(joinpath(CACHE_DIR, "heatmap_bairro_hora.png"))
    println("Heatmap de registros por bairro e hora do dia gerado.")

    println("Iniciando geração dos gráficos exploratórios com Gadfly...")
    
    # 1. Boxplot da intensidade por bairro
    p1 = Gadfly.plot(df, x=:neighbourhood, y=:intensity, Gadfly.Geom.boxplot, Gadfly.Guide.title("Intensidade por Bairro"), Gadfly.Guide.xlabel("Bairro"), Gadfly.Guide.ylabel("Intensidade"))
    Gadfly.draw(Gadfly.PNG(joinpath(CACHE_DIR, "boxplot_intensity_by_neighbourhood.png"), 600, 400), p1)
    println("Boxplot de intensidade por bairro gerado.")
    
    # 2. Histograma da intensidade dos registros
    p2 = Gadfly.plot(df, x=:intensity, Gadfly.Geom.histogram(bincount=10), Gadfly.Guide.title("Histograma da Intensidade dos Registros"), Gadfly.Guide.xlabel("Intensidade"), Gadfly.Guide.ylabel("Frequência"))
    Gadfly.draw(Gadfly.PNG(joinpath(CACHE_DIR, "histogram_intensity.png"), 600, 400), p2)
    println("Histograma da intensidade dos registros gerado.")

    # 3. Scatter plot de latitude vs longitude colorido por bairro
    p3 = Gadfly.plot(df, x=:longitude, y=:latitude, color=:neighbourhood, Gadfly.Geom.point, Gadfly.Guide.title("Localização dos Registros por Bairro"), Gadfly.Guide.xlabel("Longitude"), Gadfly.Guide.ylabel("Latitude"))
    Gadfly.draw(Gadfly.PNG(joinpath(CACHE_DIR, "scatter_lat_long_by_neighbourhood.png"), 600, 400), p3)
    println("Scatter plot de localização dos registros gerado.")

    # 4. Média da intensidade por bairro (bar plot)
    mean_intensity = combine(groupby(df, :neighbourhood), :intensity => mean => :mean_intensity)
    p4 = Gadfly.plot(mean_intensity, x=:neighbourhood, y=:mean_intensity, Gadfly.Geom.bar, Gadfly.Guide.title("Média da Intensidade por Bairro"), Gadfly.Guide.xlabel("Bairro"), Gadfly.Guide.ylabel("Média da Intensidade"))
    Gadfly.draw(Gadfly.PNG(joinpath(CACHE_DIR, "barplot_mean_intensity_by_neighbourhood.png"), 600, 400), p4)
    println("Barplot da média de intensidade por bairro gerado.")
    println("Gráficos exploratórios com Gadfly finalizados.")
    
    
    return nothing
end

end # module
