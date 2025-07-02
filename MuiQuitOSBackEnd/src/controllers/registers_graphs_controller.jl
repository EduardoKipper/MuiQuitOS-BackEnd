module RegistersGraphsController

using CSV
using DataFrames
using Statistics
using StatsBase
using Plots
using Gadfly
using Dates

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
    return nothing
end

end # module
